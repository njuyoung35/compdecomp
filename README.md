# compdecomp

공유 워크스페이스 압축/복원 도구 모음. 사용 빈도가 낮은 프로젝트 디렉토리를
무손실 압축(`.tar.xz`)하고, 필요할 때 원본 상태로 복원합니다.

## 구성 파일 (4개)

| 파일 | 역할 |
|---|---|
| `compress.sh` | `COMPRESS-TARGETS.txt` 에 나열된 디렉토리를 `.tar.xz` 로 압축 |
| `decompress.sh` | `.tar.xz` 압축 파일을 원본 디렉토리로 복원 |
| `COMPRESS-TARGETS.txt` | 압축 대상 디렉토리 목록 (한 줄에 하나) |
| `NOTICE.txt` | 워크스페이스 사용자용 정리 안내문 |

## 설치 (curl 한 줄)

레포지토리를 직접 클론하지 않고, `install.sh` 진입점 하나로 4개 파일만 받아 씁니다.
설치가 끝나면 레포지토리 흔적(임시 다운로드 + `install.sh`)은 자동으로 사라지고
현재 디렉토리에 4개 파일만 남습니다.

```bash
# 방법 1: 바로 실행 (파일이 남지 않음)
curl -fsSL https://raw.githubusercontent.com/<USERNAME>/compdecomp/main/install.sh | bash

# 방법 2: 파일로 받아 실행 후 자동 삭제
curl -fsSL https://raw.githubusercontent.com/<USERNAME>/compdecomp/main/install.sh -o install.sh
./install.sh
```

이미 같은 이름의 파일이 있으면 `파일명.bak_<타임스탬프>` 로 백업한 뒤 덮어씁니다.

> `<USERNAME>` 은 레포지토리 소유자의 GitHub 사용자명으로 바꾸세요.
> 푸시 전에 `install.sh` 상단의 `GITHUB_USER` 값도 반드시 수정해야 합니다.
> (`GITHUB_USER=xxx bash install.sh` 형태로 환경변수 지정도 가능)

## 사용법

```bash
# 1. 압축 대상 목록 확인/수정
cat COMPRESS-TARGETS.txt

# 2. 압축 실행 (대상 디렉토리 -> .tar.xz, 원본 삭제 여부 확인)
./compress.sh

# 3. 복원 실행 (.tar.xz -> 원본 디렉토리)
./decompress.sh
```

자세한 내용은 `NOTICE.txt` 를 참고하세요.

## 레포지토리 만들기 (현재 원격 없음)

```bash
# GitHub 에서 빈 레포지토리를 만든 뒤:
git remote add origin git@github.com:<USERNAME>/compdecomp.git
git push -u origin main
```
