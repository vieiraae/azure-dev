param name string

@description('The name of the API')
@minLength(1)
param apiName string

@description('The Display Name of the API')
@minLength(1)
param apiDisplayName string

@description('The description of the API')
@minLength(1)
param apiDescription string

@description('The path of the API')
@minLength(1)
param apiPath string

@description('URL for the backend API')
param apiBackendUrl string

resource apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: name
}

resource restApi 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: apiName
  parent: apimService
  properties: {
    description: apiDescription
    displayName: apiDisplayName
    path: apiPath
    protocols: [ 'https' ]
    subscriptionRequired: false
    type: 'http'
    format: 'openapi'
    serviceUrl: apiBackendUrl
    value: loadTextContent('../../../../api/common/openapi.yaml')    
  }
}

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-12-01-preview' = {
  name: 'policy'
  parent: restApi
  properties: {
    format: 'rawxml'
    value: loadTextContent('./apim-api-policy.xml')
  }
}


resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' existing = {
  name: 'app-insights-logger'
  parent: apimService
}

resource apiDiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2021-12-01-preview' = {
  name: 'applicationinsights'
  parent: restApi
  properties: {
    alwaysLog: 'allErrors'
    backend: {
      request: {
        body: {
          bytes: 1024
        }
      }
      response: {
        body: {
          bytes: 1024
        }                              
      }
    }
    frontend: {
      request: {
        body: {
          bytes: 1024
        }
      }
      response: {
        body: {
          bytes: 1024
        }
      }
    }
    httpCorrelationProtocol: 'W3C'
    logClientIp: true
    loggerId: apimLogger.id
    metrics: true
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
    verbosity: 'verbose'
  }
}

output SERVICE_API_URI string = '${apimService.properties.gatewayUrl}/${restApi.properties.path}'
