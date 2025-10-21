/**
 * @description API v2.0 Router 예제
 */
public class APIRouterV2 implements APIRouter {
    private CompositeRouter compositeRouter;

    /**
     * @description 생성자 - 라우트 초기화
     */
    public APIRouterV2() {
        this.compositeRouter = new CompositeRouter();
        this.initializeRoutes();
    }

    /**
     * @description 라우트 초기화 (상대 경로 사용)
     */
    private void initializeRoutes() {
        // 헬스 체크 엔드포인트 (상대 경로) - 재사용 가능
        this.compositeRouter.addProcessor('/health', new HealthCheckProcessor());

        // 추가 라우트 (상대 경로 사용)
        // this.compositeRouter.addProcessor('/status', new StatusProcessor());
    }

    /**
     * @description APIRouter 인터페이스 구현
     * @param aPath 요청 경로
     * @return 매칭된 APIProcessor
     */
    public APIProcessor route(String aPath) {
        return this.compositeRouter.route(aPath);
    }
}
