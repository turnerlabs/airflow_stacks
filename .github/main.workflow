workflow "Build Airflow Container" {
  on = "push"
  resolves = ["GitHub Action for Docker"]
}

action "Build Docker image" {
  uses = "actions/docker/cli@master"
  args = ["build", "--rm -t", "turnerlabs/docker-airflow", "-f", "docker/Dockerfile"]
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@76ff57a6c3d817840574a98950b0c7bc4e8a13a8"
}
