# 캐릭터 성장형 가계부: 레츠고 가계부

<p align="center">
  <img width="900" height="500" alt="나만의 펫과" src="https://github.com/user-attachments/assets/69f735d3-d2ef-46aa-8784-b543b669c0f6" />
</p>



> **"소비를 기록하면 캐릭터가 자라나는 즐거운 자산 관리 경험"**
> 지루한 가계부 쓰기를 게임처럼! 나의 소비 습관이 캐릭터의 성장 에너지가 됩니다.

---
## 다운로드
<p align="left">
  <a href="여기에_구글_플레이스토어_링크_입력">
    <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play" height="80">
  </a>
</p>

## 주요 기능 
- 수입/지출 기록
- 소비 통계 및 월별 캘린더
- 캐릭터 성장 및 수집 시스템
- 일일 퀘스트 및 보상
- 감정 기반 소비 기록
---

## 🛠 기술 스택
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
<img src="https://img.shields.io/badge/Supabase-000000?style=for-the-badge&logo=supabase&logoColor=3FCF8E">

## 프로젝트 구조 

```text
lib/
├── app/                
├── features/            
│   ├── account_book/    
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   ├── stats/
│   │   └── calendart/
│   ├── gamification/     
│   │   ├── character/
│   │   ├── shop/
│   │   └── quest/
│   ├── user/             
│   │   ├── auth/
│   │   └── my_page/
│   └── shared/        
│       ├── model/       
│       ├── notifier/   
│       └── service/    
├── utils/               
└── main.dart
