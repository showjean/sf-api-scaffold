Apex code 는 영어로, 주석은 한국어로 작성해줘.

System.assertEquals() 는 사용하지말고 네임스페이스없이 Assert 클래스를 사용해. 그리고, Assert.areEqual() 를 우선 사용해.

또, validation rule 은 metadata 의 errorMessage 노드 값으로 검증하고, @isTest 는 대문자 I 를 이용해서 @IsTest 로 표기해.

실패 케이스들은 별도의 메서드로 만들고, 클래스와 메서드에 ApexDoc 을 남겨줘. @description 은 필수록 ApexDoc 에 포함해.

Exception 검증은 e.getMessage() 를 이용해.

테스트 메서드에는 System.runAs(new User(Id = UserInfo.getUserId())) 를 적용해.

Object 의 validation rule 과 trigger 의 로직도 반영해서 만들어.

Apex 는 익명 클래스를 사용할 수 없으므로, 필요한 경우 inner class 로 구현한다.

System.debug 메서드를 이용할 때 반드시 LoggingLevel 을 지정한다.

if 문은 반드시 2줄 이상 작성한다.

인스턴스 메서드와 속성에는 this. 를 붙인다.

.cls 파일 생성시 반드시 .cls-meta.xml 파일도 함께 생성한다.

# 코딩 스타일
- 지역변수는 프리픽스 'k' 를 붙여서 사용해.
- 메서드 파라메터는 프리픽스 'a' 를 붙여서 사용해.
- 클래스 속성에는 프리픽스를 붙이지마.
- 클래스는 PascalCase, 메서드는 camelCase 로 작성해.
- Unit test 메서드는 'test' 로 시작해.
- Unit test 클래스 이름은 '_ts' 접미사를 붙여서 작성해.ui