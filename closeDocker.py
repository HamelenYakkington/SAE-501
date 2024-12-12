import utilsPython.runDockerCommand as runDocker

def main():
    try:
        api_directory = "api"
        runDocker.run_docker_command("docker compose down", cwd=api_directory)
    except Exception as e:
        print(f"{type(e).__name__} - {e}")
    
if __name__ == "__main__":
    main()
