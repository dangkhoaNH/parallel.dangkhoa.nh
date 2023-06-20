import os
import subprocess
import sys

def get_num_users():
    # Number of users for test: Get from command line
    if len(sys.argv) > 1:
        # Get the first argument from the command line and convert to integer
        return int(sys.argv[1])
    else:
        # If argument not founded, auto set 10 users
        return 10

def get_template_file():
    if len(sys.argv) > 2:
        # Get the second argument from the command line and store into variable
        return sys.argv[2]
    else:
        return "registerCourse"

def delete_cases():
    # Count testcases files and clear if num_users_current < num_users_before
    testcases_files_exists = os.listdir(target_directory_testcases)
    num_existing_test_cases = len(testcases_files_exists)

    if num_users < num_existing_test_cases:
        for i in range(num_users + 1, num_existing_test_cases + 1):
            test_file_name = f"test{i}.robot"
            test_file_path = os.path.join(target_directory_testcases, test_file_name)
            if os.path.exists(test_file_path):
                os.remove(test_file_path)

def create_accounts():
    # Check folder exists or not, if no exists => create
    if not os.path.exists(target_directory_data):
        os.makedirs(target_directory_data)

    with open(os.path.join(target_directory_data, "account.dat"), "w") as file:
        for i in range(1, num_users + 1):
            username = f"studentbk{i:02d}"
            password = "123456"

            file.write(f"[Student {i}]\n")
            file.write(f"USERNAME={username}\n")
            file.write(f"PASSWORD={password}\n\n")
    
    print("Create {num_users} accounts successfully")

def create_test_files():
    # Check folder exists or not, if no exists => create
    if not os.path.exists(target_directory_testcases):
        os.makedirs(target_directory_testcases)

    with open(template_file, "r") as file:
        template_content = file.read()

    for i in range(1, num_users + 1):
        test_content = template_content.replace("{{test_number}}", str(i))
        test_file_name = f"test{i}.robot"
        test_file_path = os.path.join(target_directory_testcases, test_file_name)

        with open(test_file_path, "w") as file:
            file.write(test_content)
    
    print("Create {num_users} testcases successfully")

def run_cmd():
    command = f"pabot --pabotlib --processes {num_users} --resourcefile {target_directory_data}/account.dat {target_directory_testcases}/."
    subprocess.run(command, shell=True)
        
if __name__ == "__main__":

    # Path FILE
    template_file = "testcase_%s_template.robot" % (get_template_file())
    target_directory_testcases = "testcases"
    target_directory_data = "data"
    
    num_users = get_num_users()

    create_accounts()
    create_test_files()
    delete_cases()
    run_cmd()