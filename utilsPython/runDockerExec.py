import subprocess

def run_docker_exec_command(container_name, command):
    try:
        command = ["docker", "exec", container_name] + command

        
        process = subprocess.Popen(command, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        for line in process.stdout:
            print(line.strip(), flush=True)

        stdout, stderr = process.communicate()


        if process.returncode == 0:

            if stdout:
                print(f"Sortie de la commande :\n{stdout}")
        else:
            print(f"Erreur lors de l'exécution de la commande : {command}")
            print(f"Code de retour : {process.returncode}")
            message_error = f"Message d'erreur :\n{stderr.strip()}"
            if stderr:
                print(f"Message d'erreur :\n{stderr.strip()}")
                message_error += f"Message: {stderr.strip()}"
            
            raise(Exception(f"{message_error}") )
    except Exception as e:
        raise e
