import subprocess

def run_docker_exec_command(container_name, command):
    try:
        docker_command = f"docker exec {container_name} {command}"
        process = subprocess.Popen(docker_command, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        process.wait()

        if process.returncode == 0:
            print("Command done : " + command)
        else:
            print(f"Erreur lors de l'exécution de la commande. Code de retour : {process.returncode}")
        
    except Exception as e:
        print(f"Erreur inconnue lors de l'exécution de la commande dans le container : {e}")