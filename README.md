# ConvertToBlueGreen

A Serverless Application for use in CloudFormation as a Custom Resource to convert an in-place deployment group to a blue/green group.

This version is intended to be used as a CloudFormation Custom Resource and expects three properties:

* CodeDeployApplication - The name of the CodeDeploy application that contains the deployment group that will be converted.
* CodeDeployDeploymentGroup - The name of the CodeDeploy deployment group that will be converted.
* AutoScalingGroup - The name of the AutoScaling Group that will be used for the Blue/Green deployment.

## Example Usage

``` yaml
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      ...

  CodeDeployApplication:
    Type: AWS::CodeDeploy::Application
    Properties:
      ...

  CodeDeployDeploymentGroup:
    Type: AWS::CodeDeploy::DeploymentGroup
    Properties:
      ...

  ConvertDeploymentGroupFunction:
    Type: AWS::Serverless::Application
    Properties:
      Location:
        ApplicationId: arn:aws:serverlessrepo:us-east-1:982831078337:applications/ConvertDeploymentGroup
        SemanticVersion: 1.0.0
  
  ForkRepo:
    Type: Custom::ConvertDeploymentGroup
    Properties:
      ServiceToken: !GetAtt ConvertDeploymentGroupFunction.Outputs.FunctionArn
      CodeDeployApplication: !Ref CodeDeployApplication
      CodeDeployDeploymentGroup: !Ref CodeDeployDeploymentGroup
      AutoScalingGroup: !Ref AutoScalingGroup
```
