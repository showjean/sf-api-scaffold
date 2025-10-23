/**
 * @description API 요청의 컨텍스트 정보를 담는 클래스 (Builder 패턴)
 * Created by fsj on 2025-10-22
 */
public class APIContext {
    /**
     * @description 경로 변수 맵
     */
    public Map<String, String> pathVar { get; private set; }

    /**
     * @description 프로세서 인스턴스
     */
    public APIProcessor processor { get; private set; }

    /**
     * @description URL 패턴
     */
    public String pattern { get; private set; }

    /**
     * @description 요청 URL
     */
    public String requestUrl { get; private set; }

    /**
     * @description HTTP 메서드
     */
    public String httpMethod { get; private set; }

    /**
     * @description private 생성자 - Builder를 통해서만 인스턴스 생성 가능
     * @param aBuilder Builder 인스턴스
     */
    private APIContext(Builder aBuilder) {
        this.pathVar = aBuilder.pathVar;
        this.processor = aBuilder.processor;
        this.pattern = aBuilder.pattern;
        this.requestUrl = aBuilder.requestUrl;
        this.httpMethod = aBuilder.httpMethod;
    }

    /**
     * @description APIContext Builder 클래스
     */
    public class Builder {
        private Map<String, String> pathVar;
        private APIProcessor processor;
        private String pattern;
        private String requestUrl;
        private String httpMethod;

        /**
         * @description Builder 생성자
         */
        public Builder() {
            this.pathVar = new Map<String, String>();
        }

        /**
         * @description 기존 APIContext를 복사하는 Builder 생성자
         * @param aContext 복사할 APIContext 인스턴스
         */
        public Builder(APIContext aContext) {
            this.pathVar = aContext.pathVar != null ? aContext.pathVar.clone() : new Map<String, String>();
            this.processor = aContext.processor;
            this.pattern = aContext.pattern;
            this.requestUrl = aContext.requestUrl;
            this.httpMethod = aContext.httpMethod;
        }

        /**
         * @description pathVar 설정
         * @param aPathVar 경로 변수 맵
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder pathVar(Map<String, String> aPathVar) {
            this.pathVar = aPathVar;
            return this;
        }

        /**
         * @description processor 설정
         * @param aProcessor 프로세서 인스턴스
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder processor(APIProcessor aProcessor) {
            this.processor = aProcessor;
            return this;
        }

        /**
         * @description pattern 설정
         * @param aPattern URL 패턴
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder pattern(String aPattern) {
            this.pattern = aPattern;
            return this;
        }

        /**
         * @description requestUrl 설정
         * @param aRequestUrl 요청 URL
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder requestUrl(String aRequestUrl) {
            this.requestUrl = aRequestUrl;
            return this;
        }

        /**
         * @description httpMethod 설정
         * @param aHttpMethod HTTP 메서드
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder httpMethod(String aHttpMethod) {
            this.httpMethod = aHttpMethod;
            return this;
        }

        /**
         * @description APIContext 인스턴스 생성
         * @return APIContext 생성된 APIContext 인스턴스
         */
        public APIContext build() {
            return new APIContext(this);
        }
    }
}