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
        // 반환되는 결과를 적당히 처리한다.
        /*
        1. @HttpX.. 메서드의 리턴 값으로 넘김
          => Blob 변환이나 JSON 처리를 하지안하도 된다. (Limit 에 유리)
        2. RestContext.response.responseBody 로 지정
          => Blob 변환을 해야하지만, JSON 처리를 세밀하게 할 수 있다. (null 은 제외하는 등..)
         */
        APIProcessResult kResult = APIScaffold.create('/api/*')
                // all http method
                .route('/sales/:apiId', new ApiRestRouterSales())
                .route('/:mod/:apiId', new ApiRestRouterSales())
                // 'POST' only
                .route('/impl/*', 'POST', new ApiRestRouterImpl())
                .exception(new APIDefaultExceptionHandler())
                .process(aReq, aRes);
        
        kResult.respond(aRes);
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