import utilsPython.runDockerCommand as runDocker
import utilsPython.runDockerExec as runExec
import utilsPython.displayDockerLink as displayLink

def main():
    try:
        api_directory = "api"
        runDocker.run_docker_command("docker compose up -d --build", cwd=api_directory)
        
        name_container = "api_php"
        runExec.run_docker_exec_command(name_container, "composer update")
        runExec.run_docker_exec_command(name_container, "php bin/console doctrine:database:create")
        runExec.run_docker_exec_command(name_container, "php bin/console doctrine:fixtures:load")

        displayLink.link('http://localhost:8081/', "API hosted by docker at the url : ")
    except Exception as e:
        print(f"{type(e).__name__} - {e}")


if __name__ == "__main__":
    main()
