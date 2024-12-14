import asyncio

async def run_docker_exec_command(container_name, command):
    command = ["docker", "exec", container_name] + command

    process = await asyncio.create_subprocess_exec(
        *command, 
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
        
    # Lecture asynchrone de stdout et stderr
    async def read_output(stream, label):
        while True:
            line = await stream.readline()
            if not line:
                break
            print(f"[{label}] {line.decode().strip()}", flush=True)

    # Lancer les deux tâches pour lire stdout et stderr simultanément
    await asyncio.gather(
        read_output(process.stdout, "STDOUT"),
        read_output(process.stderr, "STDERR")
    )

    # Attendre que le processus se termine
    return_code = await process.wait()

    if return_code == 0:
        print(f"{ command } : DONE")
    else:
        print(f"Erreur lors de l'exécution de la commande : {command}")
        print(f"Code de retour : {return_code}")
        raise Exception(f"Erreur d'exécution de la commande {command}")
