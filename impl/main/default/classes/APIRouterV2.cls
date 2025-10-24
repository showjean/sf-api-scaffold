/**
 * @description API v2.0 Router 예제
 */
public class APIRouterV2 extends APIRouterSuper {
    /**
     * @description 생성자 - 라우트 초기화
     */
    public APIRouterV2() {
        this.initializeRoutes();
    }

    /**
     * @description 라우트 초기화 (상대 경로 사용)
     */
    private void initializeRoutes() {
        // 헬스 체크 엔드포인트 (상대 경로) - 재사용 가능
        this.addProcessor('/status', new SimpleProcessor('status'));

        // 추가 라우트 (상대 경로 사용)
        // this.addProcessor('/status', new StatusProcessor());
    }
}
