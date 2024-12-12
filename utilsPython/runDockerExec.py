import subprocess

def run_docker_exec_command(container_name, command):
    try:
        docker_command = f"docker exec {container_name} {command}"
        
        process = subprocess.Popen(docker_command, shell=True, text=True, 
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        print(command)
        stdout, stderr = process.communicate()


        if process.returncode == 0:

            if stdout:
                print(f"Sortie de la commande :\n{stdout}")
        else:
            print(f"Erreur lors de l'exécution de la commande : {command}")
            print(f"Code de retour : {process.returncode}")
            if stderr:
                print(f"Message d'erreur :\n{stderr.strip()}")
    except Exception as e:
        raise Exception("Something went wrong : " + e)
