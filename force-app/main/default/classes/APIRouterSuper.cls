/**
 * @description APIRouterSuper
 * Created by fsj on 2025-10-22
 */
public abstract class APIRouterSuper implements APIRouter {
    private final CompositeRouter compositeRouter;
    /**
     * @description 생성자 - 라우트 초기화
     */
    public APIRouterSuper() {
        this.compositeRouter = new CompositeRouter();
    }

    /**
     * @description 하위 Router 등록
     * @param aPattern 경로 패턴
     * @param aRouter APIRouter 구현체
     */
    public void addRouter(String aPattern, APIRouter aRouter) {
        this.compositeRouter.addRouter(aPattern, aRouter);
    }

    /**
     * @description Processor 등록 (Leaf)
     * @param aPattern 경로 패턴
     * @param aProcessor APIProcessor 구현체
     */
    public void addProcessor(String aPattern, APIProcessor aProcessor) {
        this.compositeRouter.addProcessor(aPattern, aProcessor);
    }

    /**
     * @description APIRouter 인터페이스 구현
     * @param aContext APIContext 객체
     * @param aPrevPath 지나온 경로
     * @param aPath 요청 경로
     * @return 매칭 결과 APIContext, 매칭 Processor가 없으면 APIContext.processor = null 로 반환
     */
    public virtual APIContext route(APIContext aContext, String aPrevPath, String aPath) {
        return this.compositeRouter.route(aContext, aPrevPath, aPath);
    }
}