function  color = get_color(A,B)
% �õ���ɫ����[A,B]�ڵ�������ɫ�����1/255��
color = zeros(512,3);
i = 1;
for r = A(1):1/255:B(1)
    for g = A(2):1/255:B(2)
        for b = A(3):1/255:B(3)
            color(i,:) = [r g b];
            i = i+1;
        end
    end
end