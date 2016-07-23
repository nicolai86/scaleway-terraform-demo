job "isgo17outyet" {
  datacenters = ["dc1"]
  type = "system"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "isgo17outyet" {
    task "isgo17outyet" {
      driver = "exec"

      config {
        command = "isgo1.7outyet"
        args = ["-http=0.0.0.0:8080"]
      }

      artifact {
        source = "https://github.com/nicolai86/scaleway-terraform-demo/raw/master/binaries/isgo1.7outyet"

        options {
          checksum = "md5:302c575ce5b6d250d0074ce691a58980"
        }
      }

      resources {
        cpu = 20
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "isgo17outyet"
        tags = ["urlprefix-isgo17outyet.randschau.eu/"]
        port = "http"
        check {
          type = "http"
          name = "health"
          interval = "15s"
          timeout = "5s"
          path = "/"
        }
      }
    }
  }
}
