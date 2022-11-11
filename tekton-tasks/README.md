A "Task" is a reusable block of code within tekton that use a Single pod.
    - Steps : define container images to use in a task.
        image: There must be '1' image per step for each step.

When running a task, tekton creates a task-run object. 
    tkn task start hello-world 
    ☝️ This will generate a "task-run" object which is essentially the instantiated task running in k8s.

    