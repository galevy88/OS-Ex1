#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

#define MAX_COMMAND_LENGTH 100
#define MAX_ARGUMENTS 10
#define MAX_HISTORY_COMMANDS 100

// Global variables
char history_commands[MAX_HISTORY_COMMANDS][MAX_COMMAND_LENGTH];
int history_pids[MAX_HISTORY_COMMANDS];
int history_count = 0;

// Function to display the prompt
void display_prompt() {
    printf("$ ");
    fflush(stdout);
}

// Function to split the input command and its arguments
int split_command(char *command, char *arguments[]) {
    int arg_count = 0;
    char *token = strtok(command, " \n");
    while (token != NULL && arg_count < MAX_ARGUMENTS) {
        arguments[arg_count++] = token;
        token = strtok(NULL, " \n");
    }
    arguments[arg_count] = NULL;
    return arg_count;
}

// Function to execute external commands
void execute_external_command(char *command, char *arguments[]) {
    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
    } else if (pid == 0) {
        // Child process
        if (execvp(command, arguments) < 0) {
            perror("exec failed");
            exit(EXIT_FAILURE);
        }
    } else {
        // Parent process
        wait(NULL);
    }
}

// Function to execute built-in commands
void execute_builtin_command(char *command, char *arguments[]) {
    if (strcmp(command, "cd") == 0) {
        if (arguments[1] == NULL) {
            chdir(getenv("HOME"));
        } else {
            if (chdir(arguments[1]) != 0) {
                perror("chdir failed");
            }
        }
    } else if (strcmp(command, "exit") == 0) {
        exit(EXIT_SUCCESS);
    } else if (strcmp(command, "history") == 0) {
    for (int i = 0; i < history_count; i++) {
        printf("%d %s\n", history_pids[i], history_commands[i]);
        }
    }
}

int main(int argc, char *argv[], char *envp[]) {
    char command[MAX_COMMAND_LENGTH];
    char *arguments[MAX_ARGUMENTS];
    
    while (1) {
        display_prompt();
        
        // Read the input command
        if (fgets(command, MAX_COMMAND_LENGTH, stdin) == NULL) {
            perror("read failed");
            continue;
        }
        
        // Remove the newline character at the end
        command[strcspn(command, "\n")] = '\0';
        
        // Add the command to the history
        if (strlen(command) > 0) {
            strncpy(history_commands[history_count], command, MAX_COMMAND_LENGTH);
            history_pids[history_count++] = getpid();
        }
        
        // Split the command into its components
        int arg_count = split_command(command, arguments);
        if (arg_count == 0) {
            continue;
        }
        
        // Check if it is a built-in command
        if (strcmp(arguments[0], "cd") == 0 ||
            strcmp(arguments[0], "exit") == 0 ||
            strcmp(arguments[0], "history") == 0) {
            execute_builtin_command(arguments[0], arguments);
        } else {
            // Execute external command
            pid_t pid = fork();
            if (pid < 0) {
                perror("fork failed");
            } else if (pid == 0) {
                // Child process
                if (execvp(arguments[0], arguments) < 0) {
                    perror("exec failed");
                    exit(EXIT_FAILURE);
                }
            } else {
                // Parent process
                waitpid(pid, NULL, 0);
                // Save the PID of the executed command
                history_pids[history_count - 1] = pid;
            }
        }
    }
    
    return 0;
}

