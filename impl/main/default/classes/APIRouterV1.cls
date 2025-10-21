/**
 * @description API v1.0 Router 예제
 */
public class APIRouterV1 implements APIRouter {
    private final CompositeRouter compositeRouter;

    /**
     * @description 생성자 - 라우트 초기화
     */
    public APIRouterV1() {
        this.compositeRouter = new CompositeRouter();
        this.initializeRoutes();
    }

    /**
     * @description 라우트 초기화 (상대 경로 사용)
     */
    private void initializeRoutes() {
        // 헬스 체크 엔드포인트 (상대 경로)
        this.compositeRouter.addProcessor('/:id/:pw', new HealthCheckProcessor('root'));
        this.compositeRouter.addProcessor('/health', new HealthCheckProcessor('health'));
        this.compositeRouter.addProcessor('/*', new HealthCheckProcessor('***'));

        // 하위 라우터 등록 (상대 경로) - 재사용 가능
        this.compositeRouter.addRouter('/users/*', new APIRouterV2());

        // 추가 라우트는 여기에 등록 (상대 경로 사용)
        // this.compositeRouter.addProcessor('/users', new UserListProcessor());
        // this.compositeRouter.addRouter('/orders/*', new OrderRouter());
    }

    /**
     * @description APIRouter 인터페이스 구현
     * @param aContext APIContext 객체
     * @param aPrevPath 지나온 경로
     * @param aPath 요청 경로
     * @return 매칭 결과 APIContext, 매칭 Processor가 없으면 APIContext.processor = null 로 반환
     */
    public APIContext route(APIContext aContext, String aPrevPath, String aPath) {
        return this.compositeRouter.route(aContext, aPrevPath, aPath);
    }
}
