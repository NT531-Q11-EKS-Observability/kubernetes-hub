from locust import HttpUser, task, between
import random

class PetClinicUser(HttpUser):
    # Thời gian chờ ngẫu nhiên giữa các request để mô phỏng người dùng thật
    wait_time = between(1, 3)

    # Trang chủ
    @task(3)
    def load_home(self):
        self.client.get("/", verify=False)

    # Endpoint health check (để đảm bảo ứng dụng phản hồi nhanh)
    @task(1)
    def check_health(self):
        self.client.get("/actuator/health", verify=False)

    # Truy cập danh sách owner
    @task(2)
    def load_owners(self):
        self.client.get("/owners", verify=False)

    # Truy cập danh sách bác sĩ
    @task(2)
    def load_vets(self):
        self.client.get("/vets", verify=False)

    # Truy cập trang chi tiết owner ngẫu nhiên (nếu có API)
    @task(1)
    def load_owner_details(self):
        owner_id = random.randint(1, 10)
        self.client.get(f"/owners/{owner_id}", verify=False)
