/**
 * @description API v1.0 Router 예제
 */
public class APIRouterV1 implements APIRouter {
    private CompositeRouter compositeRouter;

    /**
     * @description 생성자 - 라우트 초기화
     */
    public APIRouterV1() {
        this.compositeRouter = new CompositeRouter();
        this.initializeRoutes();
    }

    /**
     * @description 라우트 초기화
     */
    private void initializeRoutes() {
        // 헬스 체크 엔드포인트
        this.compositeRouter.addProcessor('/api/v1.0/health', new HealthCheckProcessor());

        // 추가 라우트는 여기에 등록
        // this.compositeRouter.addProcessor('/api/v1.0/users', new UserListProcessor());
        // this.compositeRouter.addRouter('/api/v1.0/users/*', new UserRouter());
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
