import subprocess

def run_docker_exec_command(container_name, command):
    try:
        command.insert(0, container_name)
        command.insert(0, "exec")
        command.insert(0, "docker")

        
        process = subprocess.Popen(command, text=True, 
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        print(command)
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
