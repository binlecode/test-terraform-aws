

# IAM roles are required for the ECS container agent and ECS service scheduler. 
# create instance profile to pass the role information to the EC2 instances when they are launched.

# ecs service role

resource "aws_iam_role" "bl_test_ecs_iam_role" {
    name = "bl_test_ecs_iam_role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.bl_test_ecs_service_policy.json}"
}

data "aws_iam_policy_document" "bl_test_ecs_service_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "bl_test_ecs_iam_role_policy_attachment" {
    role = "${aws_iam_role.bl_test_ecs_iam_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


# ecs instance role

resource "aws_iam_role" "bl_test_ecs_instance_role" {
    name = "bl_test_ecs_instance_role"
    path = "/"
    assume_role_policy = "${data.aws_iam_policy_document.bl_test_ecs_instance_policy}"
}

data "aws_iam_policy_document" "bl_test_ecs_instance_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "bl_test_ecs_instance_role_policy_attachment" {
    role = "${aws_iam_role.bl_test_ecs_instance_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "bl_test_ecs_instance_profile" {
    name = "bl_test_ecs_instance_profile"
    path = "/"
    roles = ["${aws_iam_role.bl_test_ecs_instance_role.id}"]
    provisioner "local-exec" {
        command = "sleep 10"
    }
}

# setup ALB to load balance traffic across all instances

resource "aws_alb" "bl_test_ecs_alb" {
    name = "bl_test_ecs_alb"
    security_groups = [
        "${aws_security_group.bl-test-sg}"
    ]
    subnets = [
        "${aws_subnet.bl-test-subnet}"
    ]
    tags {
        Name = "bl_test_ecs_alb"
    }
}

resource "aws_alb_target_group" "bl_test_ecs_alb_target_group" {
    name = "bl_test_ecs_alb_target_group"
    port = "80"
    protocol = "HTTP"
    vpc_id = "${aws_vpc.bl-test-vpc.id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
        Name = "bl_test_ecs_alb_target_group"
    }
}

resource "aws_alb_listener" "bl_test_ecs_alb_listener" {
    load_balancer_arn = "${aws_alb.bl_test_ecs_alb.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.bl_test_ecs_alb_target_group.arn}"
        type = "forward"
    }
}