RestRequest kReq = new RestRequest();
RestResponse kRes = new RestResponse();
kReq.requestURI = '/api/v1.0/health';

APIScaffold.create('/api')
        .route('/*/*', new APIRouterV1())
        .route('/v2.0/*', new APIRouterV2())
        .process(kReq, kRes);

System.debug(LoggingLevel.WARN, kRes.responseBody.toString());