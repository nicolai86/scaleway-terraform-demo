/*
Copyright 2013 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// go17 is a web server that announces whether or not Go 1.7 has been tagged.
package main

import (
	"expvar"
	"flag"
	"html/template"
	"log"
	"net/http"
	"sync"
	"time"
)

type Server struct {
	url    string
	period time.Duration

	mu  sync.RWMutex
	yes bool
}

func NewServer(url string, period time.Duration) *Server {
	s := &Server{url: url, period: period}
	go s.poll()
	return s
}

func (s *Server) poll() {
	for !isTagged(s.url) {
		time.Sleep(s.period)
	}
	s.mu.Lock()
	s.yes = true
	s.mu.Unlock()
}

func isTagged(url string) bool {
	pollCount.Add(1) // HL
	r, err := http.Head(url)
	if err != nil {
		log.Print(err)
		pollError.Set(err.Error()) // HL
		pollErrorCount.Add(1)      // HL
		return false
	}
	return r.StatusCode == http.StatusOK
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	hitCount.Add(1) // HL
	s.mu.RLock()
	data := struct {
		Yes bool
		URL string
	}{
		Yes: s.yes,
		URL: s.url,
	}
	s.mu.RUnlock()
	err := tmpl.Execute(w, data)
	if err != nil {
		log.Print(err)
	}
}

var tmpl = template.Must(template.New("root").Parse(`
<!DOCTYPE html><html><body><center>
  <h2>Is Go 1.7 out yet?</h2>
  <h1>
  {{if .Yes}}
    <a href="{{.URL}}">YES!</a>
  {{else}}
    No.
  {{end}}
  </h1>
</center></body></html>
`))

const defaultChangeURL = "https://go.googlesource.com/go/+/go1.7"

var (
	httpAddr   = flag.String("http", "localhost:8080", "Listen address")
	pollPeriod = flag.Duration("poll", 5*time.Second, "Poll period")
	changeURL  = flag.String("url", defaultChangeURL, "Change URL")
)

func main() {
	flag.Parse()
	http.Handle("/", NewServer(*changeURL, *pollPeriod))
	log.Fatal(http.ListenAndServe(*httpAddr, nil))
}

// Exported variables OMIT
var (
	hitCount       = expvar.NewInt("hitCount")
	pollCount      = expvar.NewInt("pollCount")
	pollError      = expvar.NewString("pollError")
	pollErrorCount = expvar.NewInt("pollErrorCount")
)
