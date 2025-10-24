RestRequest kReq = new RestRequest();
RestResponse kRes = new RestResponse();
kReq.httpMethod = 'POST';
//kReq.requestURI = '/api/impl/xxx';
//kReq.requestURI = '/api/impl/sub/status';
kReq.requestURI = '/api/sales/a';

ApexRestApi.handleApi(kReq, kRes);

System.debug(LoggingLevel.WARN, kRes.responseBody.toString());