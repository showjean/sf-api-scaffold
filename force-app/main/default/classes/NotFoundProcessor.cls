/**
 * @description 404 Not Found 응답을 반환하는 Processor
 */
public class NotFoundProcessor implements APIProcessor {
    /**
     * @description 404 응답 생성
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    public void process(RestRequest aReq, RestResponse aRes) {
        Map<String, String> kResponse = new Map<String, String>{
            'error' => 'Not Found',
            'message' => 'The requested resource was not found',
            'path' => aReq.requestURI
        };

        aRes.statusCode = 404;
        aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
        aRes.addHeader('Content-Type', 'application/json');
    }
}
