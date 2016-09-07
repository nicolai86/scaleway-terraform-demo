job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "raw_exec"

      config {
        command = "fabio_v1.2.1_linux_arm"
        args = ["-proxy.addr=:80", "-registry.consul.addr", "10.1.42.116:8500", "-ui.addr=:9998"]
      }

      artifact {
        source = "https://github.com/nicolai86/scaleway-terraform-demo/raw/master/binaries/fabio_v1.2.1_linux_arm"

        options {
          checksum = "md5:6ceddfb2a048faa93d25a42e9c02efdc"
        }
      }

      resources {
        cpu = 20
        memory = 64
        network {
          mbits = 1

          port "http" {
            static = 80
          }
          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
