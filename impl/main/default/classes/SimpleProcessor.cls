/**
 * @description API Processor (예제)
 */
public class SimpleProcessor implements APIProcessor {
    final String label;
    public SimpleProcessor(String aLabel) {
        this.label = aLabel;
    }

    /**
     * @description 헬스 체크 요청 처리
     * @param aContext APIContext 객체
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
        Map<String, Object> kResponse = new Map<String, Object>{
            'status' => this.label ?? 'healthy',
            'timestamp' => Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
            'version' => '1.0.0',
            'httpMethod' => aContext.httpMethod
        };
        
        System.debug(LoggingLevel.INFO, JSON.serialize(aContext.pathVar));

        aRes.statusCode = 200;
        aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
        aRes.addHeader('Content-Type', 'application/json');
    }
}
