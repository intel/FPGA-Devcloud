### 9.4 Submit/Status/Delete Jobs Script

While in the home node, you can submit a job to compile by running the following command with your compilation file as an argument. 

```bash
job_submit <compilation_file.sh>
```

Before it starts compiling, it will ask you how many hours of compilation time you will need. Please only enter an integer (i.e. 4, 6, or 12).

<img src="https://user-images.githubusercontent.com/59750149/78049064-6eee7580-732f-11ea-923e-14e0be047a58.png" alt="image-qsub" style="zoom:80%;" />

To report the status of your latest job, type the following command:

```bash
job_status
```

![image-qstat](https://user-images.githubusercontent.com/59750149/78049499-fd62f700-732f-11ea-9d30-f7a3dfe8e292.png)

Your latest job can be terminated with the following command:

```bash
job_delete
```

<img src="https://user-images.githubusercontent.com/59750149/78050416-0b654780-7331-11ea-9c07-3b4fafbfad82.png" alt="image-qdelete" style="zoom:80%;" />

Or if you want to delete your first job compiled then use the following command with the job  name you want to terminate as an argument: 

```bash
job_delete <1234>.v-qsvr-fpga.aidevcloud
```

