import utilsPython.runDockerCommand as runDocker
import utilsPython.runDockerExec as runExec
import utilsPython.displayDockerLink as displayLink

def main():
    try:
        api_directory = "api"
        runDocker.run_docker_command(["docker", "compose", "up", "-d" ,"--build"], cwd=api_directory)
        
        name_container = "api_php"
        commands_exec_container = [
            ["composer", "update"],
            ["php", "bin/console", "doctrine:database:drop", "--if-exists" ,"--force", "--no-interaction"],
            ["php", "bin/console", "doctrine:database:create", "--no-interaction"],
            ["php", "bin/console", "doctrine:migration:migrate", "--no-interaction"],
            ["php", "bin/console", "doctrine:fixtures:load", "--no-interaction"]
        ]

        for command in commands_exec_container:
            runExec.run_docker_exec_command(name_container, command)

        print("API hosted by docker at the url : ")
        displayLink.link('http://localhost:8081/')
    except Exception as e:
        print(f"{type(e).__name__} - {e}")


if __name__ == "__main__":
    main()
