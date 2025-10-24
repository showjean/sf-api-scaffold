/**
 * @description ApexRestApi
 * Created by fsj on 2025-10-22
 */
@RestResource(UrlMapping='/api/*')
global without sharing class ApexRestApi {
    /**
     * @description http method 에 맞는 라우터를 등록한 후 처리
     * @param aReq RestRequest
     * @param aRes RestResponse
     */
    global static void handleApi(RestRequest aReq, RestResponse aRes) {
        APIScaffold.create('/api/*')
                // all http method
                .route('/sales/:apiId', new ApiRestRouterSales())
                .route('/:mod/:apiId', new ApiRestRouterSales())
                // 'POST' only
                .route('/impl/*', 'POST', new ApiRestRouterImpl())
                .exception(new APIDefaultExceptionHandler())
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
    @HttpPatch
    global static void handlePatch() {
        handleApi(RestContext.request, RestContext.response);
    }
    @HttpDelete
    global static void handleDelete() {
        handleApi(RestContext.request, RestContext.response);
    }
    @HttpPut
    global static void handlePut() {
        handleApi(RestContext.request, RestContext.response);
    }
}