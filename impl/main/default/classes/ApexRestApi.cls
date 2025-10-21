/**
 * @description ApexRestApi
 * Created by fsj on 2025-10-22
 */
@RestResource(UrlMapping='/api/*')
global without sharing class ApexRestApi {
    global static void handleApi(RestRequest aReq, RestResponse aRes) {
        APIScaffold.create('/api')
                .route('/sales/:apiId', new ApiRestRouterSales())
//                .route('/service/:apiId', new ApiRestRouterSales())
                .process(aReq, aRes);
    }
    
    @HttpPost
    global static void handlePost() {
        handleApi(RestContext.request, RestContext.response);
    }
    @HttpGet
    global static void handleGet() {
        handleApi(RestContext.request, RestContext.response);
    }
}