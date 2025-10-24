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
     * @return APIProcessResult
     */
    public APIProcessResult process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
        Map<String, Object> kResponse = new Map<String, Object>{
            'status' => this.label ?? 'healthy',
            'timestamp' => Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
            'version' => '1.0.0',
            'httpMethod' => aContext.httpMethod,
            'req' => JSON.deserializeUntyped(aReq.requestBody.toString())
        };
        
        System.debug(LoggingLevel.INFO, JSON.serialize(aContext.pathVar));

        return new APIProcessResult(200, kResponse).header(
                'Content-Type', 'application/json'
        );
    }
}
