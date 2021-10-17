## Running on Lixux 64 bits ##

Run the following commands in order to test the infrastructure as a code:

```
$ chmod +x setup.sh
./setup.sh
```

Input the variables for your AWS Account Enviroment, and be happy =]

## In other enviroments ##

You have to setup terraform enviroment, and then create into IAC folder a file with the following pattern and env.tfvars name:

```
access_key = "$AWS_ACCESS_KEY"
secret_key = "$AWS_SECRET_KEY"
region     = "$AWS_REGION"
env        = "dev|stag|prod"
```

after creating the file you need to run the following commands into IAC folder:

```
terraform init
terraform apply -var-file=env.tfvars
```
