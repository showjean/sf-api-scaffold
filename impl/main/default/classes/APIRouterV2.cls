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
     * @description 라우트 초기화
     */
    private void initializeRoutes() {
        // v2.0용 헬스 체크
        this.compositeRouter.addProcessor('/api/v2.0/health', new HealthCheckProcessor());

        // v2.0 추가 라우트
        // this.compositeRouter.addProcessor('/api/v2.0/status', new StatusProcessor());
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
