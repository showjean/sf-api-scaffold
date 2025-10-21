/**
 * @description Health Check API Processor (예제)
 */
public class HealthCheckProcessor implements APIProcessor {
    final String label;
    public HealthCheckProcessor(String aLabel) {
        this.label = aLabel;
    }

    /**
     * @description 헬스 체크 요청 처리
     * @param aReq RestRequest 객체
     * @param aRes RestResponse 객체
     */
    public void process(RestRequest aReq, RestResponse aRes) {
        Map<String, Object> kResponse = new Map<String, Object>{
            'status' => this.label ?? 'healthy',
            'timestamp' => Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
            'version' => '1.0.0'
        };

        aRes.statusCode = 200;
        aRes.responseBody = Blob.valueOf(JSON.serialize(kResponse));
        aRes.addHeader('Content-Type', 'application/json');
    }
}
