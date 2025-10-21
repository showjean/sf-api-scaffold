/**
 * @description 경로 매칭을 담당하는 인터페이스 (Composite 패턴)
 */
public interface APIRouter {
    /**
     * @description 주어진 경로에 매칭되는 Processor를 반환
     * @param aPrevPath 지나온 경로
     * @param aPath 요청 경로
     * @return 매칭된 APIProcessor, 없으면 null 반환
     */
    APIProcessor route(String aPrevPath, String aPath);
}
