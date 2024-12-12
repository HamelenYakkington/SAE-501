import subprocess

def run_docker_command(command, cwd=None):
    try:
        process = subprocess.Popen(command, shell=True, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        process.wait()

        if process.returncode == 0:
            print("Command done : " + command)
        else:
            print(f"Erreur lors de l'exécution de la commande. Code de retour : {process.returncode}")

    except Exception as e:
        print(f"Erreur inconnue lors de l'exécution de la commande : {e}")