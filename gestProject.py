import utilsPython.runDockerCommand as runDocker
import utilsPython.runDockerExec as runExec
import utilsPython.displayDockerLink as displayLink
import time
import asyncio

async def init():
    try:
        await delete()
        time.sleep(5)
        await build()
        time.sleep(5)
        
        name_container = "api_php"
        commands_exec_container = [
            ["composer", "update"],
            ["php", "bin/console" ,"importmap:install"],
            ["php", "bin/console" ,"assets:install"],
            ["php", "bin/console" ,"asset-map:compile"],
            ["php", "bin/console" ,"lexik:jwt:generate-keypair"],
            ["chown", "-R", "www-data:www-data", "/var/www/symfony"],
            ["php", "bin/console", "doctrine:database:create", "--no-interaction"],
            ["php", "bin/console", "doctrine:migration:migrate", "--no-interaction"],
            ["php", "bin/console", "doctrine:fixtures:load", "--no-interaction"]
        ]

        for command in commands_exec_container:
            await runExec.run_docker_exec_command(name_container, command)

        print("API hosted by docker at the url : ")
        displayLink.link('http://localhost:8081/')
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def start():
    try:
        await open()
        time.sleep(5)

        commands_exec_container = [
            ["composer", "update"],
            ["php", "bin/console" ,"importmap:install"],
            ["php", "bin/console" ,"assets:install"],
            ["php", "bin/console" ,"asset-map:compile"],
            ["chown", "-R", "www-data:www-data", "/var/www/symfony"],
            ["php", "bin/console", "doctrine:migration:migrate", "--no-interaction"],
            ["php", "bin/console", "doctrine:fixtures:load", "--no-interaction"]
        ]

        name_container = "api_php"

        for command in commands_exec_container:
            await runExec.run_docker_exec_command(name_container, command)

        print("API hosted by docker at the url : ")
        displayLink.link('http://localhost:8081/')
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def close():
    try:
        api_directory = "api"
        await runDocker.run_docker_command(["docker","compose","down"], cwd=api_directory)
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def open():
    try:
        api_directory = "api"
        await runDocker.run_docker_command(["docker","compose","up","-d"], cwd=api_directory)
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def delete():
    try:
        api_directory = "api"
        await runDocker.run_docker_command(["docker","compose","down", "-v"], cwd=api_directory)
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def build():
    try:
        api_directory = "api"
        await runDocker.run_docker_command(["docker", "compose", "up", "-d" ,"--build"], cwd=api_directory)
    except Exception as e:
        print(f"{type(e).__name__} - {e}")

async def main():
    good_input = False
    while good_input == False:
        good_input = True
        print("Choisissez une option :")
        print("0 : Quitter")
        print("1 : Initialiser le projet")
        print("2 : Start les containers")
        print("3 : Ferme les containers")
        print("4 : Supprimer les containers")

        choix = input("Choisissez une option (0 - 4) : ")
        if choix == '0':
            print("Exit")
        if choix == '1':
            await init()
        elif choix == '2':
            await start()
        elif choix == '3':
            await close()
        elif choix == '4':
            await delete()
        else:
            print("Choix invalide. Veuillez entrer une option entre 0 et 4.")
            good_input = True

if __name__ == "__main__":
    asyncio.run(main())
