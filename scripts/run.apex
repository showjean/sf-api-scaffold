RestRequest kReq = new RestRequest();
RestResponse kRes = new RestResponse();
kReq.requestURI = '/api/v1.0/health2';
//kReq.requestURI = '/api/v2.0/status';

APIScaffold.create('/api')
        .route('/v1.0/*', new APIRouterV1())
        .route('/v1.5/*', new APIRouterV1())
        .route('/v2.0/*', new APIRouterV2())
        .process(kReq, kRes);

System.debug(LoggingLevel.WARN, kRes.responseBody.toString());