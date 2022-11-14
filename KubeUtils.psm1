function Set-KubeCluster {
  param (
    $Cluster
  )
  $env:KUBECONFIG = "$HOME\.kube\$Cluster"
}
Register-ArgumentCompleter -CommandName Set-KubeCluster -ParameterName Cluster -ScriptBlock {
  Get-ChildItem -File ~/.kube 
    | ForEach-Object { $_.Name }
}

function Set-KubeNamespace {
  param (
    $Namespace
  )
  kubectl config set-context $(kubectl config current-context) --namespace=$Namespace
}
$CompleteKubeNamespaces = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  Write-Progress -Activity "Searching Kubernetes Namespaces"

  $completions = (kubectl get namespace -o json | ConvertFrom-Json).items 
    | ForEach-Object { $_.metadata.name } 
    | Where-Object { $_ -like "*$wordToComplete*" }

  Write-Progress -Activity "Searching Kubernetes Namespaces" -Completed

  $completions
}
Register-ArgumentCompleter -CommandName Set-KubeNamespace -ParameterName Namespace -ScriptBlock $CompleteKubeNamespaces

function Connect-KubeService {
  param (
    [string]
    $Service,
    [Int32]
    $From = 8080,
    [Int32]
    $To = 8080
  )
  kubectl port-forward service/$Service $From":"$To
}
$CompleteKubeServices = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  Write-Progress -Activity "Searching Kubernetes Services"

  $completions = (kubectl get services -o json | ConvertFrom-Json).items 
    | ForEach-Object { $_.metadata.name }
    | Where-Object { $_ -like "*$wordToComplete*" }

  Write-Progress -Activity "Searching Kubernetes Services" -Completed

  $completions
}
Register-ArgumentCompleter -CommandName Connect-KubeService -ParameterName Service -ScriptBlock $CompleteKubeServices

function Connect-KubeDeployment {
  param (
    [string]
    $Deployment,
    [Int32]
    $From = 8080,
    [Int32]
    $To = 8080
  )
  kubectl port-forward deployment/$Deployment $From":"$To
}
$CompleteKubeDeployments = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  Write-Progress -Activity "Searching Kubernetes Deployments"

  $completions = (kubectl get deployment -o json | ConvertFrom-Json).items 
    | ForEach-Object { $_.metadata.name }
    | Where-Object { $_ -like "*$wordToComplete*" }

  Write-Progress -Activity "Searching Kubernetes Deployments" -Completed

  $completions
}
Register-ArgumentCompleter -CommandName Connect-KubeDeployment -ParameterName Service -ScriptBlock $CompleteKubeDeployemnts

function Get-KubeLogs {
  param (
    [Parameter(Position=0)]
    [String]
    $App,
    [String]
    $Pod,
    [Switch]
    $Follow,
    [int]
    $Tail
  )

  $selector = ""

  if ($Pod) {
    $selector = $Pod
  } elseif ($App) {
    $selector = "-l app=$App"
  }

  $flags = @()

  if ($Follow) {
    $flags += "-f"
  }
  if ($Tail) {
    $flags += "--tail=$Tail"
  }

  kubectl logs $selector $flags | ForEach-Object { ConvertFrom-Json $_ }
}
