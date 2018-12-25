package main

import (
    "log"
    "github.com/soundcloud/go-runit/runit"
)

func main() {
    log.Printf("Running runit-health")

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

    // Print success message
    log.Printf("runit-health check successful")
}
