clear;
load('pMapN.mat');%load perspective map
im = dir('**\*.jpg');%load img
m=640;n=360;
pool = 1.0;
m=m/pool/4;%%pooling
n=n/pool/4;
gt = [];
traingt = [];
testgt = [];

for idx=1:length(im)
    imgname = im(idx).name;
    matname = imgname;
    matname(end-2:end) = 'mat';
    load(['**' matname]);%gt.mat path
    loc = ceil(loc/pool/4);
    dmap = zeros(m,n);
    for i=1:size(loc,1)
        if(loc(i,2)<=0)
            loc(i,2)=1;
        end
        if(loc(i,1)<=0)
            loc(i,1)=1;
        end
        if(loc(i,2)>m)
            loc(i,2)=m;
        end
        if(loc(i,1)>n)
            loc(i,1)=n;
        end
        dmap(loc(i,2),loc(i,1))=1;
    end
   gt = loc;%

   d_map = zeros(m,n);
   for j=1:size(gt,1)
       ksize = ceil(25/sqrt(pMapN(floor(gt(j,2)),1)));
       ksize = max(ksize,3);
       ksize = min(ksize,25);
       radius = ceil(ksize/2);
       sigma = ksize/2.5;
       h = fspecial('gaussian',ksize,sigma);
       x_ = max(1,floor(gt(j,1)));
       y_ = max(1,floor(gt(j,2)));
       
       if (x_-radius+1<1)
              for ra = 0:radius-x_-1
                   h(:,end-ra) = h(:,end-ra)+h(:,1);
                   h(:,1)=[];
              end
       end  
       if (y_-radius+1<1)
           for ra = 0:radius-y_-1
               h(end-ra,:) = h(end-ra,:)+h(1,:);
               h(1,:)=[];
           end
       end
       if (x_+ksize-radius>n)   
           for ra = 0:x_+ksize-radius-n-1
               if(size(h,2)==0)
                   continue;
               end
               if(1+ra>size(h,2))
                    ra = size(h,2)-1;
               end
               if(size(h,2)==0)
                    continue;
                end
               h (:,1+ra) = h(:,1+ra)+h(:,end);
               h(:,end) = [];
           end
       end
       if(y_+ksize-radius>m)    
            for ra = 0:y_+ksize-radius-m-1
                if(1+ra>size(h,1))
                    ra = size(h,1)-1;
                end
                if(size(h,1)==0)
                    continue;
                end
                h (1+ra,:) = h(1+ra,:)+h(end,:);
                h(end,:) = [];
            end
       end             
          d_map(max(y_-radius+1,1):min(y_+ksize-radius,m),max(x_-radius+1,1):min(x_+ksize-radius,n))...
             = d_map(max(y_-radius+1,1):min(y_+ksize-radius,m),max(x_-radius+1,1):min(x_+ksize-radius,n))...
              + h;
   end
    d_map_name = ['**' matname];%save path
    save(d_map_name,'d_map');

end
       


