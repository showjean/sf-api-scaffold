/**
 * @description 경로 매칭을 담당하는 인터페이스 (Composite 패턴)
 */
public interface APIRouter {
    /**
     * @description 주어진 경로에 매칭되는 Processor를 반환
     * @param aContext APIContext 객체
     * @param aPrevPath 지나온 경로
     * @param aPath 요청 경로
     * @return 매칭 결과 APIContext, 매칭 Processor가 없으면 APIContext.processor = null 로 반환
     */
    APIContext route(APIContext aContext, String aPrevPath, String aPath);
}
