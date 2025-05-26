    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
        }
      }
    }

    provider "google" {
      project = "elated-bus-460108-d0"
      credentials = "./elated-bus-460108-d0-5386335d5b12.json"
    }