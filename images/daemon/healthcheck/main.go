package main

import (
    "log"
    "os"
    "net/http"
    "github.com/soundcloud/go-runit/runit"
)

func main() {
    log.Printf("Running healthcheck")

    // Get runit services
    services, err := runit.GetServices("/etc/service")
    if err != nil {
		log.Fatal(err)
	}

    // Check runit services
    for _, service := range services {
        log.Printf("Checking service '%s'", service.Name)
        status, err := service.Status()
		if err != nil {
			log.Fatal(err)
		}
        if status.State != runit.StateUp {
			log.Fatalf("Service '%s' is not running", service.Name)
		}
    }

    // Run HTTP healthcheck if enabled
    url, urlExists := os.LookupEnv("HEALTHCHECK_URL")
    if !urlExists {
        log.Printf("Skipping HTTP check. HEALTHCHECK_URL is not set")
    } else {
        log.Printf("Running HTTP check on URL '%s'", url)
        res, err := http.Get(url)
        if err != nil {
            log.Fatal(err)
        }
        if res.StatusCode < 200 || res.StatusCode > 299 {
            log.Fatalf("Invalid status code '%s'", res.StatusCode)
        }
    }

    // Print success message
    log.Printf("Healthcheck successful")
}
