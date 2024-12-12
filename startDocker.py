import utilsPython.runDockerCommand as runDocker
import utilsPython.displayDockerLink as displayLink

def main():
    try:
        api_directory = "api"
        runDocker.run_docker_command("docker compose up -d", cwd=api_directory)

        print("API hosted by docker at the url : ")
        displayLink.link('http://localhost:8081/')
    except Exception as e:
        print(f"{type(e).__name__} - {e}")
    
if __name__ == "__main__":
    main()
