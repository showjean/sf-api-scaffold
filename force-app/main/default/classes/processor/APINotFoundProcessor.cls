/**
 * @description 404 Not Found 응답을 반환하는 Processor
 */
public class APINotFoundProcessor implements APIProcessor {
    /**
     * @description 404 응답 생성
     * @param aContext APIContext 객체
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
        APIResponse kResponse = new APIResponse.Builder()
                .success(false)
                .error('Not Found', 'The requested resource was not found')
                .requestUrl(aReq.requestURI)
                .build();
        aRes.statusCode = 404;
        aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
        aRes.addHeader('Content-Type', 'application/json');
    }
}
