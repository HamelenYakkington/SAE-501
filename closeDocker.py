import utilsPython.runDockerCommand as runDocker

def main():
    api_directory = "api"
    runDocker.run_docker_command("docker compose down", cwd=api_directory)
    
if __name__ == "__main__":
    main()
