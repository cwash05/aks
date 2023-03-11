# KEDA Cluster
Built with the base cluster.  This script sets up a service bus enviornment to demonstate 
the KEDA service bus scaler using Workload Identity
<br>

Deployment is based off https://github.com/kedacore/sample-dotnet-worker-servicebus-queue#net-core-worker-processing-azure-service-bus-queue-scaled-by-keda


#### Deploy to a location that supports Zones
run
```cli
./keda-aksdeploy.sh
```


Once created, you will see that our deployment shows up with no pods created:

```cli
❯ kubectl get deployments --namespace $aksPrefix-ns -o wide
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       CONTAINERS        IMAGES                                                   SELECTOR
order-processor   0         0         0            0           49s       order-processor   kedasamples/sample-dotnet-worker-servicebus-queue   app=order-processor
```

Configure the connection string with the outputted infromation in the tool via your favorite text editor, in this case via Visual Studio Code:

```cli
❯ code ./src/Keda.Samples.Dotnet.OrderGenerator/Program.cs
```
Next, you can run the order generator via the CLI:
```cli
❯ dotnet run --project ./src/Keda.Samples.Dotnet.OrderGenerator/Keda.Samples.Dotnet.OrderGenerator.csproj
```
Let's queue some orders, how many do you want?
300
Queuing order 719a7b19-f1f7-4f46-a543-8da9bfaf843d - A Hat for Reilly Davis
Queuing order 5c3a954c-c356-4cc9-b1d8-e31cd2c04a5a - A Salad for Savanna Rowe
[...]

Now that the messages are generated, you'll see that KEDA starts automatically scaling out your deployment:

```cli
❯ kubectl get deployments --namespace keda-dotnet-sample -o wide
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       CONTAINERS        IMAGES                                                   SELECTOR
order-processor   8         8         8            4           4m        order-processor   kedasamples/sample-dotnet-worker-servicebus-queue   app=order-processor
```