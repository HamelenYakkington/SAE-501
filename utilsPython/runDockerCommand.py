import subprocess

def run_docker_command(command, cwd=None):
    try:
        process = subprocess.Popen(command, shell=True, text=True, 
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=cwd)
        
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